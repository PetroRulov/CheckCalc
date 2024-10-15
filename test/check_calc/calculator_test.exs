defmodule CheckCalc.CalculatorTest do
  use ExUnit.Case
  use ExUnitProperties

  require Decimal
  require Logger

  alias CheckCalc.Support.Generators

  describe "Product generation" do
    property "if buy-one-get-one-free (bogof) true, discount stuff for Product is not applicable" do
      products = Generators.product_generator() |> Enum.take(10)
      Logger.warning("PRODUCTS: #{inspect(products)}")

      check all(product <- Generators.product_generator()) do
        assert %CheckCalc.Struct.Product{} = product
        assert is_binary(product.code)
        assert Decimal.is_decimal(product.price)
        assert is_boolean(product.bogof)

        if product.bogof do
          assert product.discount_bulk == nil
          assert product.discount == nil
        else
          if product.discount_bulk != nil do
            assert is_integer(product.discount_bulk)
          end

          if product.discount != nil do
            assert is_number(product.discount)
          end
        end
      end
    end
  end
end
