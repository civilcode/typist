defmodule Typist.Generator do
  def build(calling_module, {module_name, :t}, metadata) do
    module = Module.concat([calling_module, module_name])

    quote do
      alias unquote(module)

      defmodule unquote(module) do
        def __type__ do
          unquote(Macro.escape(metadata))
        end
      end
    end
  end

  def build(calling_module, %{ast: {:"::", _, [{module_name, :t}, type]}} = metadata) do
    module = Module.concat([calling_module, module_name])

    quote do
      alias unquote(module)

      defmodule unquote(module) do
        def __type__ do
          unquote(Macro.escape(%{metadata | ast: type}))
        end
      end
    end
  end

  def build(_calling_module, metadata) do
    quote do
      def __type__ do
        unquote(Macro.escape(metadata))
      end
    end
  end
end