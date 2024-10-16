defmodule CheckCalc.CalculatorTest do
  use ExUnit.Case
  use ExUnitProperties

  require Decimal
  require Logger

  alias CheckCalc.Calculator
  alias CheckCalc.Struct.Product
  alias CheckCalc.Support.Generators

  describe "Product generation" do
    property "if buy-one-get-one-free (bogof) true, discount stuff for Product is not applicable" do
#      products = Generators.product_generator() |> Enum.take(10)
#      Logger.warning("PRODUCTS: #{inspect(products)}")

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

  describe "calculate Product value" do
    test "calculate Product value when bogof equal to false and discount_bulk not defined (nil)" do
      quantity = 10
      test_product1 = %Product{
        code: "T1",
        name: "Test product 1",
        price: %Decimal{coef: 1000, exp: -2},
        bogof: false,
        discount_bulk: nil,
        discount: 0.85
      }

      result1 = Calculator.calculate_discount_value(test_product1, quantity)
               |> Decimal.round(2, :ceiling)
               |> Decimal.to_float()
      expected_result1 = 85.0
      assert  expected_result1 == result1

      test_product2 = %Product{
        code: "T2",
        name: "Test product 2",
        price: %Decimal{coef: 1000, exp: -2},
        bogof: false,
        discount_bulk: nil,
        discount: nil
      }

      result2 = Calculator.calculate_discount_value(test_product2, quantity)
               |> Decimal.round(2, :ceiling)
               |> Decimal.to_float()
      expected_result2 = 100.0
      assert  expected_result2 == result2
    end
  end


end
