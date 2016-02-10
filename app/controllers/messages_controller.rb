class MessagesController < ApplicationController
  before_action :set_message, only: [:show]
  before_action :invite_only
  
  # for message folders
  def inbox
    @folders = current_user.message_folders
  end
  
  def add_image
  end
  
  def instant_messages
    @group = Group.find_by_id(params[:group_id])
    @instant_messages = []
    # from group or secret chat between two users
    @messages = @group.messages if @group
    for message in @messages
      @instant_messages << message if check_last_im(message)
    end
    set_last_im
  end

  # GET /messages
  # GET /messages.json
  def index
    msg_limit = 3 # how many to display
    @new_message = Message.new
    @group = Group.find_by_id(params[:group_id])
    if @group
      cookies.permanent[:last_chat_id] = @group.id
      @messages ||= @group.messages.last msg_limit
      set_last_im
    end
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
  end

  # POST /messages
  # POST /messages.json
  def create
    @new_message = Message.new # for ajax, new form
    @group = Group.find_by_id params[:group_id]
    @message = Message.new(message_params)
    @message.user_id = current_user.id
    @message.group_id = params[:group_id]
    @message.save!
  end

  private
    def invite_only
      unless invited?
        redirect_to invite_only_path
      end
    end
  
    def check_last_im message
      # eval to inflate hash from string
      in_sequence = false; last_im = eval(cookies[:last_im].to_s)
      if last_im.class.eql? Hash and message.id > last_im[:message_id].to_i
        if @group and last_im[:group_id].eql? @group.id
          in_sequence = true # meaning not the last message
        end
      end
      return in_sequence
    end
    
    # keeps track of last message loaded
    def set_last_im
      message_id = if @instant_messages.present?
        @instant_messages.last.id
      # last message on page load, before ajax call
      elsif @group and @group.messages.present?
        @group.messages.last.id
      else
        nil
      end
      last_im = { message_id: message_id }
      last_im[:group_id] = @group.id
      cookies[:last_im] = last_im.to_s if last_im[:message_id]
    end
    
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:user_id, :group_id, :body, :image)
    end
end
