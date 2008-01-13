class ModeratorshipsController < ApplicationController
  def create
    @moderatorship = Moderatorship.new(params[:moderatorship])

    respond_to do |format|
      if @moderatorship.save
        flash[:notice] = 'Moderatorship was successfully created.'
        format.html { redirect_to(@moderatorship.user) }
        format.xml  { render :xml  => @moderatorship, :status => :created, :location => @moderatorship }
      else
        flash[:error] = "Moderatorship could not be created: #{@moderatorship.errors.full_messages.to_sentence}"
        format.html { redirect_to(@moderatorship.user) }
        format.xml  { render :xml  => @moderatorship.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @moderatorship = Moderatorship.find(params[:id])
    @moderatorship.destroy

    respond_to do |format|
      format.html { redirect_to(@moderatorship.user) }
      format.xml  { head :ok }
    end
  end
end
