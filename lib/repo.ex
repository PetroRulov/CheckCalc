defmodule CheckCalc.Repo do
  @moduledoc false

  alias CheckCalc.Struct.Product

  @two_thirds 2 / 3

  def all(Product) do
    [
      %Product{
        code: "GR1",
        name: "Green tea",
        price: %Decimal{coef: 311, exp: -2},
        bogof: true,
        discount_bulk: nil,
        discount: nil
      },
      %Product{
        code: "SR1",
        name: "Strawberries",
        price: %Decimal{coef: 500, exp: -2},
        bogof: false,
        discount_bulk: 3,
        discount: 0.9
      },
      %Product{
        code: "CF1",
        name: "Coffee",
        price: %Decimal{coef: 1123, exp: -2},
        bogof: false,
        discount_bulk: 3,
        discount: @two_thirds
      }
    ]
  end

  def all(_module), do: []
end
