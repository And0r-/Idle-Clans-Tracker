class Admin::ItemValuesController < Admin::BaseController
  before_action :set_item_value, only: [:edit, :update]
  
  def index
    @item_values = ItemValue.all.order(:item_name)
  end
  
  def edit
  end
  
  def update
    if @item_value.update(item_value_params)
      redirect_to admin_item_values_path, notice: 'Item-Wert wurde aktualisiert.'
    else
      render :edit
    end
  end
  
  private
  
  def set_item_value
    @item_value = ItemValue.find(params[:id])
  end
  
  def item_value_params
    params.require(:item_value).permit(:points_per_unit, :active)
  end
end