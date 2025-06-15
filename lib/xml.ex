defmodule Xml do
  require Record
  Record.defrecord(:xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl"))
  Record.defrecord(:xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl"))

  Record.defrecord(
    :xmlAttribute,
    Record.extract(:xmlAttribute, from_lib: "xmerl/include/xmerl.hrl")
  )

  @spec parse_string(String.t()) :: record(:xmlElement)
  def parse_string(content) do
    content = to_charlist(content)
    {doc, _rest} = :xmerl_scan.string(content)
    doc
  end

  @spec export_string(record(:xmlElement)) :: String.t()
  def export_string(doc) do
    [doc]
    |> :xmerl.export_simple(:xmerl_xml)
    |> to_string()
    |> Kernel.<>("\n")
  end

  @typep mapper :: (:xmerl.element() -> :xmerl.element())
  @spec traverse_and_update_elements(:xmerl.element(), mapper) :: :xmerl.element()
  def traverse_and_update_elements(element, func) do
    updated_element = func.(element)

    case updated_element do
      xmlElement(content: content) ->
        updated_content =
          Enum.map(content, fn child -> traverse_and_update_elements(child, func) end)

        xmlElement(updated_element, content: updated_content)

      other ->
        other
    end
  end

  @spec find_attribute_value(record(:xmlElement), atom) :: charlist | nil
  def find_attribute_value(element, name) do
    xmlElement(attributes: attributes) = element

    attributes
    |> Enum.find_value(fn
      xmlAttribute(name: ^name, value: value) -> value
      _ -> nil
    end)
  end

  @spec add_attribute(record(:xmlElement), atom, charlist) :: record(:xmlElement)
  def add_attribute(element, name, value) do
    xmlElement(attributes: attributes) = element

    new_attribute = xmlAttribute(name: name, value: value)
    updated_attributes = [new_attribute | attributes]

    xmlElement(element, attributes: updated_attributes)
  end

  @spec update_attribute(record(:xmlElement), atom, charlist) :: record(:xmlElement)
  def update_attribute(element, name, value) do
    xmlElement(attributes: attributes) = element

    updated_attributes =
      attributes
      |> Enum.map(fn
        xmlAttribute(name: ^name) = attribute -> xmlAttribute(attribute, value: value)
        attribute -> attribute
      end)

    xmlElement(element, attributes: updated_attributes)
  end

  @spec has_attribute?(record(:xmlElement), atom) :: boolean
  def has_attribute?(element, name) do
    xmlElement(attributes: attributes) = element

    attributes
    |> Enum.any?(fn
      xmlAttribute(name: ^name) -> true
      _ -> false
    end)
  end

  @spec update_or_add_attribute(record(:xmlElement), atom, charlist) :: record(:xmlElement)
  def update_or_add_attribute(element, name, value) do
    if has_attribute?(element, name) do
      update_attribute(element, name, value)
    else
      add_attribute(element, name, value)
    end
  end

  @spec charlist_to_number(charlist) :: float
  def charlist_to_number(x) do
    x |> to_string() |> Float.parse() |> elem(0)
  end

  @spec number_to_charlist(integer | float) :: charlist
  def number_to_charlist(x) do
    if is_float(x) do
      :erlang.float_to_binary(x, decimals: 2) |> to_charlist()
    else
      Integer.to_string(x) |> to_charlist()
    end
  end
end
