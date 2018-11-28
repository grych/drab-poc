defmodule DrabPoc.DocsView do
  use DrabPoc.Web, :view

  def moduledoc(module) do
    {_line, md} = Code.get_docs(module, :moduledoc)
    "#{Earmark.as_html(md, %Earmark.Options{code_class_prefix: "elixir"})}"
  end

  # function - a tuple of {funcion_name, arity}
  def funcdoc(module, function) do
    {_function, _line, _def, _arguments, doc} = Code.get_docs(module, :docs) |> Enum.find(fn(x) -> elem(x, 0) == function end)
    Earmark.as_html(doc)
  end
end
