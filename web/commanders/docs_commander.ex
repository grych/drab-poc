defmodule DrabPoc.DocsCommander do
  require IEx
  require Logger

  use Drab.Commander, onload: :page_loaded

  def qs_1_click(socket, dom_sender) do
    val = socket |> select(:val, from: "#qs_1_text") |> inspect
    socket |> update(:text, set: val, on: "#qs_1_out")
    {socket, dom_sender}
  end

  def qs_2_click(socket, dom_sender) do
    val = socket |> select(:text, from: ".qs_2") |> inspect
    socket |> update(:text, set: val, on: "#qs_2_out")
    {socket, dom_sender}
  end

  def qs_3_click(socket, dom_sender) do
    attr = socket |> select(attr: "class", from: ".qs_2") |> inspect
    socket |> update(:text, set: attr, on: "#qs_3_out")
    {socket, dom_sender}
  end

  def qs_4_click(socket, dom_sender) do
    css = socket |> select(css: "font", from: ".qs_2")
    socket |> update(:text, set: css, on: "#qs_4_out")
    {socket, dom_sender}
  end

  def qu_1_click(socket, dom_sender) do
    socket |> update(:text, set: "new <u>text</u>", on: "#qu_1_span")
    {socket, dom_sender}
  end

  def qu_2_click(socket, dom_sender) do
    socket |> update(:html, set: "new <u>html</u>", on: "#qu_1_span")
    {socket, dom_sender}
  end

  def qu_3_click(socket, dom_sender) do
    socket |> update(attr: "style", set: "font-family: monospace", on: "#qu_1_span")
    {socket, dom_sender}
  end

  def qu_4_click(socket, dom_sender) do
    socket |> update(class: "btn-primary", set: "btn-danger", on: this(dom_sender))
    {socket, dom_sender}
  end
  
  def qu_5_click(socket, dom_sender) do
    socket |> update(css: "border", set: "3px solid red", on: this(dom_sender))
    {socket, dom_sender}
  end

  def qi_1_click(socket, dom_sender) do
    socket |> insert(" <b>inserted</b> ", before: "#qi_1_span")

    {socket, dom_sender}
  end

  def qi_2_click(socket, dom_sender) do
    socket |> insert(" <i>inserted</i> ", after: "#qi_1_span")
    {socket, dom_sender}
  end

  def qi_3_click(socket, dom_sender) do
    socket |> insert(" <u>prepended</u> ", prepend: "#qi_1_span")
    {socket, dom_sender}
  end

  def qi_4_click(socket, dom_sender) do
    socket |> insert(" <small>appended</small> ", append: "#qi_1_span")
    {socket, dom_sender}
  end

  def qd_1_click(socket, dom_sender) do
    socket |> delete(class: "btn btn-primary", from: this(dom_sender))
    {socket, dom_sender}
  end

  def qd_2_click(socket, dom_sender) do
    socket |> delete(from: "#qd_2_pre")
    {socket, dom_sender}
  end

  def qd_3_click(socket, dom_sender) do
    socket |> delete("#qd_3_pre")
    {socket, dom_sender}
  end

  def a_1_click(socket, dom_sender) do
    socket |> alert("Title", "Just a message")
    {socket, dom_sender}
  end

  def a_2_click(socket, dom_sender) do
    {button, _} =
      socket |> alert("Message", "What is the answer?", ok: "42", cancel: "Don't know")
    socket |> update(:text, set: "clicked #{button} button", on: this(dom_sender))
    {socket, dom_sender}
  end

  def a_3_click(socket, dom_sender) do
    form = "<input name='first' class='form-control'><input id='second' class='form-control'>"
    response = case socket |> alert("What's your name?", form, ok: "A juści", cancel: "Poniechaj") do
      { :ok, params } -> "first is #{params["first"]}, and second: #{params["second"]}"
      { :cancel, _ }  -> "you cancelled!"
    end
    socket |> update(:text, set: response, on: this(dom_sender))
    {socket, dom_sender}
  end

  def a_4_click(socket, dom_sender) do
    {socket, dom_sender}
  end

  def a_5_click(socket, dom_sender) do
    {socket, dom_sender}
  end

  def page_loaded(socket) do
    socket
  end
end
