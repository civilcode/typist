defmodule Typist.Code do
  # Convert a block of fields to a type
  def to_spec({:__block__, _, ast}) do
    ast = to_fields(ast)

    quote location: :keep do
      @type t :: %__MODULE__{unquote_splicing(ast)}
    end
  end

  def to_spec({:|, _, _} = ast) do
    quote location: :keep do
      @type t :: unquote(ast)
    end
  end

  # Convert a block to a struct
  def to_struct({:__block__, _, ast}) do
    ast = to_fields(ast) |> Map.new() |> Map.keys()

    quote location: :keep do
      defstruct [unquote_splicing(ast)]
    end
  end

  def to_fields({:__block__, _, ast}) do
    to_fields(ast)
  end

  def to_fields([]) do
    []
  end

  def to_fields([head | tail]) do
    [to_fields(head) | to_fields(tail)]
  end

  # Convert `{:"::", _, [{:price, _, nil}, {:integer, _, []}]}` to {:price, {:integer, _, []}}
  # which will be used to generate the fields for a record type.
  def to_fields({:"::", _, [{field, _, _}, type]}) do
    quote location: :keep do
      {unquote(field), unquote(type)}
    end
  end

  def module(content, caller_module, module_name, extra \\ []) do
    alias_name = Module.concat([caller_module] ++ [List.first(module_name)])
    module = Module.concat([caller_module] ++ module_name)

    quote do
      unquote(extra)

      alias unquote(alias_name)

      defmodule unquote(module) do
        unquote(content)
      end
    end
  end
end
