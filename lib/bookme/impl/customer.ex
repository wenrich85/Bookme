defmodule Bookme.Impl.Customer do
  defstruct ~w[email name company type phone]a

  def new(%{name: name, email: email, phone: phone}) do
    %__MODULE__{
      email: email,
      name: name,
      phone: phone
    }
  end

  def new(%{email: email, name: name, company: company, phone: phone}) do
    %__MODULE__{
      email: email,
      phone: phone,
      name: name,
      company: company
    }
  end
  def new(%{name: name, company: company, type: type, email: email, phone: phone}) do
    %__MODULE__{
      email: email,
      phone: phone,
      name: name,
      company: company,
      type: type
    }
  end
end
