defmodule CheckCalc.Calculator do
  @moduledoc false

  alias CheckCalc.Struct.Product

  @spec calculate_check(list()) :: {:ok, {map(), Decimal.t()}} | {:error, {atom(), any()}}
  def calculate_check(products) do
    products_map =
      Enum.reduce(products, %{}, fn product, acc ->
        code = product["code"]
        quantity = String.to_integer(product["quantity"])
        Map.update(acc, code, quantity, &(&1 + quantity))
      end)

    calculate_groupped_products(products_map)
  end

  @spec calculate_groupped_products(map()) ::
          {:ok, {map(), Decimal.t()}} | {:error, {atom(), any()}}
  def calculate_groupped_products(products_map) do
    result =
      Enum.reduce(products_map, {[], Decimal.new("0.0")}, fn {code, quantity}, {acc, total} ->
        product = get_product(code)
        product_value = calculate_product_value(product, quantity)

        {[{product.code, product.name, product.price, quantity} | acc],
         total
         |> Decimal.add(product_value)
         |> Decimal.normalize()}
      end)

    {:ok, result}
  end

  @spec calculate_product_value(Product.t(), non_neg_integer()) :: Decimal.t()
  def calculate_product_value(product, quantity) do
    case product.bogof do
      true ->
        calculate_bogof_value(product, quantity)

      false ->
        calculate_discount_value(product, quantity)
    end
  end

  def calculate_bogof_value(product, quantity) do
    case quantity > 1 do
      true ->
        product.price
        |> Decimal.mult(%Decimal{coef: quantity * 100, exp: -2})
        |> Decimal.sub(product.price)
        |> Decimal.normalize()

      false ->
        product.price
    end
  end

  def calculate_discount_value(product, quantity) do
    discount = get_product_discount(product)

    case product.discount_bulk == nil do
      true ->
        calc_product_value(product, quantity, discount)

      false ->
        calc_with_bulk_value(product, quantity, discount)
    end
  end

  def calc_product_value(product, quantity, discount) do
    product.price
    |> Decimal.mult(%Decimal{coef: quantity * 100, exp: -2})
    |> Decimal.mult(discount)
    |> Decimal.normalize()
  end

  def calc_with_bulk_value(product, quantity, discount) do
    case quantity >= product.discount_bulk do
      true ->
        calc_product_value(product, quantity, discount)

      false ->
        product.price
        |> Decimal.mult(%Decimal{coef: quantity * 100, exp: -2})
        |> Decimal.normalize()
    end
  end

  ## --- / a u x i l i a r y   f u n c t i o n s / ---
  defp get_product_discount(product) do
    case product.discount == nil do
      true ->
        %Decimal{coef: 100, exp: -2}

      false ->
        Decimal.from_float(product.discount)
    end
  end

  defp get_product(code),
    do: Enum.find(get_products(), fn %{code: repo_code} -> repo_code == code end)

  defp get_products(), do: CheckCalc.Repo.all(Product)
end
