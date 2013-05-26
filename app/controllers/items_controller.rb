class ItemsController < InheritedResources::Base
  protect_from_forgery :except => [:tag_suggestions]

  
  layout :conditional_layout
  respond_to :html, :xml, :js, :json
  before_filter :authenticate_user!, :only => [:new, :edit, :create]
  helper :users, :transfers
  
  has_scope :on_hold
  has_scope :accepted 
  has_scope :requested
  has_scope :on_transfer
  has_scope :multiple
  has_scope :need
  has_scope :offer
  has_scope :good
  has_scope :service
  has_scope :transport
  has_scope :idea
  has_scope :sharingpoint

  def index
    @geolocation = session[:geo_location]
		@itemable = find_model
    @itemTypes = ItemType.all
  	@searchItemType = "Resource"
		@near = (request.location.city.blank?) ? params[:near] : request.location.city 
    if params[:user_id] && current_user && params[:user_id].to_i == current_user.id.to_i
      @userSubtitle = "i"
    else
      @userSubtitle = "user"
    end
    
    # search
    $search = Item.search(params[:q], :indlude => [:comments, :images, :pings])	
    if params[:q] and !params[:q][:tag] and params[:near].blank?
                  	
      @items = $search.result(:distinct => true).paginate( 
        :page => params[:page],
        :order => "created_at DESC", 
        :per_page => ITEMS_PER_PAGE 
      )
      @items_count = @items.count

			# search by itemType
		  if not params[:q][:item_type_id_eq].blank?
		    @searchItemType = ItemType.find(params[:q][:item_type_id_eq]).title.to_s
		  end
      
			# search itemable items
			if @itemable
				$search = @itemable.items.search(params[:q], :indlude => [:comments, :images, :pings])
		    case @itemable.class.to_s
		    when "User"
					@user = @itemable
		      @active_menuitem_l1 = I18n.t "menu.main.resources"
		      @active_menuitem_l1_link = user_items_path         
		      @active_menuitem_l2 = @searchItemType.downcase
		      @active_menuitem_l2_link = user_items_path("q" => params[:q])
		      render :layout => 'userarea'
				when "Group"
		      @group = @itemable       
		      @active_menuitem_l1 = I18n.t "menu.main.resources"
		      @active_menuitem_l1_link = group_items_path         
		      @active_menuitem_l2 = @searchItemType.downcase
		      @active_menuitem_l2_link = group_items_path("q" => params[:q])
		      render :layout => 'groups'
		    end
			end

    elsif params[:q] && params[:q][:tag]
      # search by tag
      $search = searchByTag(params, "Item").search(params[:q])
		
		elsif params[:q] && (params[:within]	or params[:near])
			# search within certain range
			$search = searchByRangeIn("Item")
			@items = $search.result(:distinct => true).paginate( 
        :page => params[:page],
        :order => "created_at DESC", 
        :per_page => ITEMS_PER_PAGE 
      )
      @items_count = @items.count
    else
			# normal listing of a model's items
      if @itemable
				$search = @itemable.items.search(params[:q], :indlude => [:comments, :images, :pings])

        @active_menuitem_l1 = I18n.t "menu.main.resources"   
        @active_menuitem_l1_link = eval "#{@itemable.class.to_s.downcase}_items_path"
        
        @items_offered = @itemable.items.offered
        @items_needed = @itemable.items.needed
				@used_resources = Item.where('accounts.accountable_id' => @itemable.id, 'accounts.accountable_type' => @itemable.class.to_s)
        @items_taken = @used_resources.taken 
        @items_given = @used_resources.given
        
      
				case @itemable.class.to_s
				when "User"
					@user = @itemable
					@owner = @user.login
	        render :layout => 'userarea'
				when "Group"
					@group = @itemable
					@owner = @group.title
				  render :layout => 'groups'
				end

			else
				$search = Item.search(params[:q], :indlude => [:comments, :images, :pings])
      end
      @items = $search.result(:distinct => true).paginate( 
        :page => params[:page],
        :order => "created_at DESC", 
        :per_page => ITEMS_PER_PAGE 
      )
      @items_count = @items.count
    end
	
    # save search    
		saveSearch
  end
  
  def search
    index
    render :index
  end
  
  def show
		@itemable = find_model
    @item = Item.find(params[:id], :include => [:images, :pings, :comments, :locations, :events, :tags, :item_attachments])
    @user = current_user

    # related resources
    @titleParts = @item.title.split(" ")

    if @item.need == true
      @items_related_tagged_same = Item.offered.tagged_with(@item.tags.join(', ')).where(:item_type_id => @item.item_type_id)
      @titleParts.each do |part|
          @items_related_titled_same = Item.offered.where(:title => "%#{part}%") if part.length.to_i >= 5
      end
      @items_related_title = I18n.t("item.related.offer").html_safe
			@ping_body_msg = I18n.t("ping.pingBodyMessageOnNeed");
			@ping_submit = I18n.t("ping.this.need");
    else
      @items_related_tagged_same = Item.needed.tagged_with(@item.tags.join(', ')).where(:item_type_id => @item.item_type_id)
      @titleParts.each do |part|
        @items_related_titled_same = Item.needed.where(:title => "%#{part}%") if part.length.to_i >= 5
      end
      @items_related_title = I18n.t("item.related.need").html_safe
			@ping_body_msg = I18n.t("ping.pingBodyMessageOnOffer");
			@ping_submit = I18n.t("ping.this.offer");
    end

    if not @items_related_titled_same.nil?
      @items_related = @items_related_tagged_same + @items_related_titled_same
    else
      @items_related = @items_related_tagged_same
    end

    @pings = @item.pings.open_or_accepted
    @comments = @item.comments.find(:all, :order => "created_at DESC")
    @events = @item.events
    @location = @item.locations.first # || @item.itemable.locations.first
    getLocation(@item) if @location and @location.lat and @location.lng
    @resource = @item
    getItemTypes
		impressionist(@item)
  end
  
  def new
		@itemable = find_model
    @item = Item.new
    @user = current_user
    
    @active_menuitem_l1 = I18n.t "menu.main.resources"   
    @active_menuitem_l1_link = eval "#{@itemable.class.to_s.downcase}_items_path"
    @item.locations.build
    @item.events.build
		case @itemable.class.to_s
		when "User"
			@user = @itemable
      render :layout => 'userarea'
		when "Group"
			@group = @itemable
		  render :layout => 'groups'
		end

    # @item.images.build
    # @item.item_attachments.build
    
    getItemTypes
  end
  
  def edit
		@itemable = find_model
    @item = @itemable.items.find(params[:id], :include => [:locations, :events])    
    @location = @item.locations.first || @item.locations.build
    @event = @item.events.first || @item.events.build
		@event.from = @event.from.to_s(:forms) if @event.from
		@event.till = @event.till.to_s(:forms) if @event.till
    getLocation(@item) if @location.lat and @location.lng
    @user = User.find(@item.user_id)
    getItemTypes
  end
  
  def update
		@itemable = find_model
    @item = current_user.items.find(params[:id])
   # @item.images = Image.new(params[:item][:images_attributes])
    getItemTypes
  
    if @item.update_attributes(params[:item])
      flash[:notice] = t("flash.items.update.notice")
      redirect_to @item
    else
      render :action => 'edit'
    end
  end
  
  def create
		@itemable = find_model
    @item = Item.new(params[:item])
    @user = current_user
    getItemTypes
    #@item.location = Location.new(params[:item][:location_attributes])
    create!
  end
  
  def destroy
		@itemable = find_model
    @item = Item.find(params[:id])
    @item.destroy
		if @itemable
    	redirect_to @itemable
		else
			redirect_to collection
		end
  end

  def follow
    @item = Item.find(params[:id])
    if current_user.following?(@item)
      flash[:notice] = t("flash.items.follow.error.alreadyFollowing")
    else
      current_user.follow(@item)
      flash[:notice] = t("flash.items.follow.notice", :title => @item.title)
    end
    
    redirect_to(@item)
  end

	def like
    @item = Item.find(params[:id])
		likeOf(current_user, @item)
	end

	def unlike
    @item = Item.find(params[:id])
		unlikeOf(current_user, @item)
	end
  
  def rate
    @item = Item.find(params[:id])
    @item.rate(params[:stars], current_user, params[:dimension])
    id = "ajaxful-rating-#{!params[:dimension].blank? ? "#{params[:dimension]}-" : ''}item-#{@item.id}"
    render :update do |page|
      page.replace_html id, ratings_for(@item, :wrap => false, :dimension => params[:dimension])
      page.visual_effect :highlight, id
    end
  end
  
  def tag_suggestions
    @context = params[:c]
    if @context 
       @tags = User.tag_counts_on(@context).find(:all, :conditions => ["name LIKE ?", "%#{params[:term]}%"], :limit=> params[:limit] || 5)
    else
       @tags = Item.tag_counts_on("tags").find(:all, :conditions => ["name LIKE ?", "%#{params[:term]}%"], :limit=> params[:limit] || 5)
    end
    
    #@tags.join(',').split(',')
    render  :json => @tags.join(',').split(',')
  end

  private

	def saveSearch
	  if not params[:q][:title_cont].blank?     
		  @keywords = params[:q][:title_cont].to_s.split
		  @keyword_items = ""
		  @keywords.each do |keyword|
		    if @keywords.last == keyword then
		      @keyword_items += "(:title =~ '%#{keyword}%' )"  
		    else
		      @keyword_items += "(:title =~ '%#{keyword}%' ) | "  
		    end
		  end
		
		  @searcher ||= current_user.id if current_user  
		  for keyword in @keywords
		   Search.create(:keyword => keyword, :user_id => @searcher, :ip => request.env['REMOTE_ADDR'])
		  end 
		end
	end
  
  def getLocation(item)
    @locations_json = item.locations.to_gmaps4rails
  end
  
  def getItemTypes
    @itemTypes = Hash.new
    ItemType.all.each do |it|
      localized_title = t(it.title.downcase, :count => 1).gsub("1 ", "")
      @itemTypes[localized_title] = it.id 
    end
  end
  
  protected
  
  def collection 
    @items ||= end_of_association_chain.paginate(
      :page => params[:page],
      :per_page => 24,
      :include => :pings, 
      :order => "#{@sort_by} #{@direction}"
    )
  end
  
  def conditional_layout
    case action_name
      when "new", "edit" then "userarea"
      else "application"
    end
  end
  
end
