defmodule CheckCalcWeb.PageControllerTest do
  use CheckCalcWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ expected_page_structure()
  end

  def expected_page_structure() do
    "<!DOCTYPE html>\n<html lang=\"en\">\n  <head>\n    <meta charset=\"utf-8\">\n "
  end
end
