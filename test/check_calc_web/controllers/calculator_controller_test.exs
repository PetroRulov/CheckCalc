defmodule CheckCalcWeb.CalculatorControllerTest do
  use CheckCalcWeb.ConnCase

  require Logger

  setup do
    :ok
  end

  test "route to compose new order page page", %{conn: conn} do
    new_conn = get(conn, Routes.calculator_path(conn, :compose_order))
    assert html_response(new_conn, 200) =~ "ADD NEW PRODUCTS:"
  end

  test "calculate empty order", %{conn: conn} do
    products = [""]
    new_conn = post(conn, Routes.calculator_path(conn, :calculate, %{"products" => products}))
    assert Map.get(new_conn.private, :phoenix_flash) == %{"info" => "Total price expected: £0.0"}
    assert html_response(new_conn, 200) =~ "Total price expected: £0.0"
  end

  test "calculate non-empty order", %{conn: conn} do
    products = non_groupped_order()
    result = 66.61
    new_conn = post(conn, Routes.calculator_path(conn, :calculate, %{"products" => products}))

    assert Map.get(new_conn.private, :phoenix_flash) ==
             %{
               "info" => [
                 "Basket: ",
                 "SR1, Strawberries - 4 x £5.00 |\n",
                 "GR1, Green tea - 7 x £3.11 |\n",
                 "CF1, Coffee - 4 x £11.23 |\n"
               ]
             }

    assert html_response(new_conn, 200) =~ "Total price expected: £66.61"
    assert Map.get(new_conn.assigns, :result) == result
  end

  test "show result", %{conn: conn} do
    new_conn = get(conn, Routes.calculator_path(conn, :result, 66.61))

    assert html_response(new_conn, 200) =~ "Total price expected: £66.61"
  end

  test "test calculate two buy-one-get-one-free (bogof) product in order", %{conn: conn} do
    products = two_bogof_products_order()
    result = 3.11
    new_conn = post(conn, Routes.calculator_path(conn, :calculate, %{"products" => products}))

    assert Map.get(new_conn.private, :phoenix_flash) ==
             %{
               "info" => [
                 "Basket: ",
                 "GR1, Green tea - 2 x £3.11 |\n"
               ]
             }

    assert html_response(new_conn, 200) =~ "Total price expected: £3.11"
    assert Map.get(new_conn.assigns, :result) == result
  end

  test "test calculate one buy-one-get-one-free (bogof) product in order", %{conn: conn} do
    products = one_bogof_product_order()
    result = 13.11
    new_conn = post(conn, Routes.calculator_path(conn, :calculate, %{"products" => products}))

    assert Map.get(new_conn.private, :phoenix_flash) ==
             %{
               "info" => [
                 "Basket: ",
                 "SR1, Strawberries - 2 x £5.00 |\n",
                 "GR1, Green tea - 1 x £3.11 |\n"
               ]
             }

    assert html_response(new_conn, 200) =~ "Total price expected: £13.11"
    assert Map.get(new_conn.assigns, :result) == result
  end

  test "test order with product quantity less than discount_bulk", %{conn: conn} do
    products = product_quantity_less_than_discount_bulk()
    result = 32.46
    new_conn = post(conn, Routes.calculator_path(conn, :calculate, %{"products" => products}))

    assert Map.get(new_conn.private, :phoenix_flash) ==
             %{
               "info" => [
                 "Basket: ",
                 "SR1, Strawberries - 2 x £5.00 |\n",
                 "CF1, Coffee - 2 x £11.23 |\n"
               ]
             }

    assert html_response(new_conn, 200) =~ "Total price expected: £32.46"
    assert Map.get(new_conn.assigns, :result) == result
  end

  def non_groupped_order() do
    %{
      "3" => %{"code" => "GR1", "quantity" => "1"},
      "4" => %{"code" => "CF1", "quantity" => "2"},
      "5" => %{"code" => "SR1", "quantity" => "1"},
      "6" => %{"code" => "GR1", "quantity" => "5"},
      "7" => %{"code" => "SR1", "quantity" => "3"},
      "8" => %{"code" => "GR1", "quantity" => "1"},
      "9" => %{"code" => "CF1", "quantity" => "2"}
    }
  end

  def two_bogof_products_order() do
    %{
      "3" => %{"code" => "GR1", "quantity" => "2"}
    }
  end

  def one_bogof_product_order() do
    %{
      "3" => %{"code" => "GR1", "quantity" => "1"},
      "4" => %{"code" => "SR1", "quantity" => "2"}
    }
  end

  def product_quantity_less_than_discount_bulk() do
    %{
      "3" => %{"code" => "SR1", "quantity" => "2"},
      "4" => %{"code" => "CF1", "quantity" => "2"}
    }
  end
end
