class StructuresController < ApplicationController
  def open_container
    if params[:id]
      container = Structure.find_by(id: params[:id])
      if container
        render partial: 'structures/cargocontainer', locals: {items: container.get_items}
        return
      end
    end
    render json: {}, status: 400
  end
end