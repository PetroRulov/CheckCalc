defmodule CheckCalc.Support.Generators do
  use ExUnitProperties

  require Logger

  alias CheckCalc.Struct.Product

  def product_generator do
    unconditional_fields_gen = %{
      code: StreamData.string(:alphanumeric, length: 3),
      name: StreamData.string(:alphanumeric, length: 3..20),
      price: StreamData.integer(1..10000) |> StreamData.map(&%Decimal{coef: &1, exp: -2}),
      bogof: StreamData.boolean()
    }

    StreamData.fixed_map(unconditional_fields_gen)
    |> StreamData.bind(fn base_fields ->
      case base_fields.bogof do
        true ->
          StreamData.constant(%{
            discount_bulk: nil,
            discount: nil
          })
          |> StreamData.map(&Map.merge(base_fields, &1))

        false ->
          discount_fields_gen = %{
            discount_bulk: discount_bulk_generator(),
            discount: discount_generator(0.01, 0.99)
          }

          StreamData.fixed_map(discount_fields_gen)
          |> StreamData.map(&Map.merge(base_fields, &1))
      end
    end)
    |> StreamData.map(fn product_fields -> struct(Product, product_fields) end)
  end

  defp discount_bulk_generator do
    StreamData.frequency([
      {1, StreamData.constant(nil)},
      {3, StreamData.integer(2..12)}
    ])
  end

  defp discount_generator(min, max) when is_number(min) and is_number(max) do
    StreamData.frequency([
      {1, StreamData.constant(nil)},
      {2,
       StreamData.float()
       |> StreamData.filter(fn float -> float >= min and float <= max end)
       |> StreamData.map(fn float -> Float.ceil(float, 2) end)}
    ])
  end
end
