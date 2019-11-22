defmodule Typist.DiscriminatedUnionTest do
  use ExUnit.Case
  use Typist

  describe "defining the type inline" do
    deftype FormalName :: String.t()
    deftype Nickname :: String.t()
    deftype FirstLast :: {String.t(), String.t()}

    deftype Name :: Nickname.t() | FirstLast.t() | FormalName.t() | binary

    test "defines the type meta-data" do
      actual_type = Name.__type__()

      assert match?(%Typist.DiscriminatedUnionType{}, actual_type)
      assert :Name == actual_type.name

      assert actual_type.spec() ==
               "@type(t :: Nickname.t() | FirstLast.t() | FormalName.t() | binary)"
    end

    test "defines a constructor function" do
      assert %Nickname{value: "Jimmy"} = Name.new(%Nickname{value: "Jimmy"})
    end
  end

  describe "defining the type in a module" do
    defmodule Foo do
      deftype Nickname :: String.t()

      defmodule Name do
        deftype Nickname.t() | FirstLast.t() | FormalName.t()
      end
    end

    test "defines the type meta-data" do
      actual_type = Foo.Name.__type__()

      assert match?(%Typist.DiscriminatedUnionType{}, actual_type)
      assert :Name == actual_type.name

      assert actual_type.spec ==
               "@type(t :: Nickname.t() | FirstLast.t() | FormalName.t())"
    end

    test "defines a constructor function" do
      assert %Foo.Nickname{value: "Jimmy"} == Foo.Name.new(%Foo.Nickname{value: "Jimmy"})
    end
  end
end
