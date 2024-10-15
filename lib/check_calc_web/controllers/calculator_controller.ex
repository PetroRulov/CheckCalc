defmodule CheckCalcWeb.CalculatorController do
  use CheckCalcWeb, :controller

  require Logger

  alias CheckCalc.Calculator

  def calculate(conn, %{"products" => def_products}) do
    Logger.info("DEF_pRODUCTS: #{inspect(def_products)}")

    case is_map(def_products) do
      true ->
        products = Map.values(def_products)
        Logger.info("CONTROLLER_PRODUCTS: #{inspect(products)}")

        {:ok, {order_items_list, total}} = Calculator.calculate_check(products)
        result = total |> Decimal.round(2, :ceiling) |> Decimal.to_float()
        Logger.info("RESULT: #{inspect(result)}")
        msg = compose_message(order_items_list)

        conn
        |> put_flash(:info, msg)
        |> render("action.html", result: result, mark: "result")

      false ->
        conn
        |> put_flash(:info, <<"Total price expected: £0.0">>)
        |> render("action.html", result: "0.00", mark: "result")
    end
  end

  def compose_order(conn, %{}) do
    render(conn, "action.html", products: [], mark: "new_order")
  end

  def result(conn, %{"result" => result}) do
    render(conn, "results.html", %{result: result})
  end

  def compose_message(order_items_list) do
    # {"SR1", "Strawberries", Decimal.new("5.00"), 1},
    Enum.reduce(order_items_list, ["Basket: "], fn {code, name, price, quantity}, acc ->
      acc ++
        [
          code <>
            ", " <>
            name <>
            " - " <>
            Integer.to_string(quantity) <>
            " x £" <>
            Decimal.to_string(price) <>
            " |\n"
        ]
    end)
  end
end
