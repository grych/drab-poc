defmodule Drab.Controller do
  defmacro __using__(options) do
    quote do
      Module.put_attribute(__MODULE__, :__drab_opts__, unquote(options))

      import Drab.Query

      unless Module.defines?(__MODULE__, {:__drab__, 0}) do
        def __drab__() do
          opts = Enum.into(@__drab_opts__, %{controller: __MODULE__})
          Map.merge(%Drab.Config{}, opts) 
        end
      end
    end
  end
end
