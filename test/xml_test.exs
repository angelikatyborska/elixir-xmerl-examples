defmodule XmlTest do
  use ExUnit.Case
  require Xml
  doctest Xml

  @string_input """
  <?xml version="1.0"?><svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
    <circle id="circle-1" cx="50" cy="50" r="50" fill="red"/>
    <circle id="circle-2" cx="50" cy="50" r="30" fill="orange"/>
    <circle id="circle-3" cx="50" cy="50" r="10" fill="yellow"/>
  </svg>
  """

  @xml_element_input {:xmlElement, :svg, :svg, [],
                      {:xmlNamespace, :"http://www.w3.org/2000/svg", []}, [], 1,
                      [
                        {:xmlAttribute, :viewBox, [], [], [], [svg: 1], 1, [], ~c"0 0 100 100",
                         false},
                        {:xmlAttribute, :xmlns, [], [], [], [svg: 1], 2, [],
                         ~c"http://www.w3.org/2000/svg", false}
                      ],
                      [
                        {:xmlText, [svg: 1], 1, [], ~c"\n  ", :text},
                        {:xmlElement, :circle, :circle, [],
                         {:xmlNamespace, :"http://www.w3.org/2000/svg", []}, [svg: 1], 2,
                         [
                           {:xmlAttribute, :id, [], [], [], [circle: 2, svg: 1], 1, [],
                            ~c"circle-1", false},
                           {:xmlAttribute, :cx, [], [], [], [circle: 2, svg: 1], 2, [], ~c"50",
                            false},
                           {:xmlAttribute, :cy, [], [], [], [circle: 2, svg: 1], 3, [], ~c"50",
                            false},
                           {:xmlAttribute, :r, [], [], [], [circle: 2, svg: 1], 4, [], ~c"50",
                            false},
                           {:xmlAttribute, :fill, [], [], [], [circle: 2, svg: 1], 5, [], ~c"red",
                            false}
                         ], [], [], ~c"/Users/angelika/Documents/code/xml", :undeclared},
                        {:xmlText, [svg: 1], 3, [], ~c"\n  ", :text},
                        {:xmlElement, :circle, :circle, [],
                         {:xmlNamespace, :"http://www.w3.org/2000/svg", []}, [svg: 1], 4,
                         [
                           {:xmlAttribute, :id, [], [], [], [circle: 4, svg: 1], 1, [],
                            ~c"circle-2", false},
                           {:xmlAttribute, :cx, [], [], [], [circle: 4, svg: 1], 2, [], ~c"50",
                            false},
                           {:xmlAttribute, :cy, [], [], [], [circle: 4, svg: 1], 3, [], ~c"50",
                            false},
                           {:xmlAttribute, :r, [], [], [], [circle: 4, svg: 1], 4, [], ~c"30",
                            false},
                           {:xmlAttribute, :fill, [], [], [], [circle: 4, svg: 1], 5, [],
                            ~c"orange", false}
                         ], [], [], ~c"/Users/angelika/Documents/code/xml", :undeclared},
                        {:xmlText, [svg: 1], 5, [], ~c"\n  ", :text},
                        {:xmlElement, :circle, :circle, [],
                         {:xmlNamespace, :"http://www.w3.org/2000/svg", []}, [svg: 1], 6,
                         [
                           {:xmlAttribute, :id, [], [], [], [circle: 6, svg: 1], 1, [],
                            ~c"circle-3", false},
                           {:xmlAttribute, :cx, [], [], [], [circle: 6, svg: 1], 2, [], ~c"50",
                            false},
                           {:xmlAttribute, :cy, [], [], [], [circle: 6, svg: 1], 3, [], ~c"50",
                            false},
                           {:xmlAttribute, :r, [], [], [], [circle: 6, svg: 1], 4, [], ~c"10",
                            false},
                           {:xmlAttribute, :fill, [], [], [], [circle: 6, svg: 1], 5, [],
                            ~c"yellow", false}
                         ], [], [], ~c"/Users/angelika/Documents/code/xml", :undeclared},
                        {:xmlText, [svg: 1], 7, [], ~c"\n", :text}
                      ], [], ~c"/Users/angelika/Documents/code/xml", :undeclared}

  describe "parse_string/1" do
    test "turns a string into an xmlElement record" do
      assert Xml.parse_string(@string_input) == @xml_element_input
    end
  end

  describe "export_string/1" do
    test "turns a string into an xmlElement record" do
      assert Xml.export_string(@xml_element_input) == @string_input
    end
  end

  describe "traverse_and_update_elements/2" do
    test "runs function on all elements" do
      func = fn
        Xml.xmlElement(attributes: attributes) = element ->
          new_attribute = Xml.xmlAttribute(name: :foo, value: ~c"bar")
          updated_attributes = [new_attribute | attributes]
          Xml.xmlElement(element, attributes: updated_attributes)

        child ->
          child
      end

      expected = """
      <?xml version="1.0"?><svg foo="bar" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
        <circle foo="bar" id="circle-1" cx="50" cy="50" r="50" fill="red"/>
        <circle foo="bar" id="circle-2" cx="50" cy="50" r="30" fill="orange"/>
        <circle foo="bar" id="circle-3" cx="50" cy="50" r="10" fill="yellow"/>
      </svg>
      """

      assert @xml_element_input |> Xml.traverse_and_update_elements(func) |> Xml.export_string() ==
               expected
    end
  end

  describe "find_attribute_value/2" do
    test "when it exists" do
      assert Xml.find_attribute_value(@xml_element_input, :xmlns) ==
               ~c"http://www.w3.org/2000/svg"
    end

    test "when it does not exist" do
      assert Xml.find_attribute_value(@xml_element_input, :foo) == nil
    end
  end

  describe "add_attribute/2" do
    test "adds attribute" do
      name = :width
      value = ~c"120"

      expected = """
      <?xml version="1.0"?><svg width="120" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
        <circle id="circle-1" cx="50" cy="50" r="50" fill="red"/>
        <circle id="circle-2" cx="50" cy="50" r="30" fill="orange"/>
        <circle id="circle-3" cx="50" cy="50" r="10" fill="yellow"/>
      </svg>
      """

      assert @xml_element_input
             |> Xml.add_attribute(name, value)
             |> Xml.export_string() ==
               expected
    end
  end

  describe "update_attribute/2" do
    test "updates attribute" do
      name = :viewBox
      value = ~c"0 10 120 130"

      expected = """
      <?xml version="1.0"?><svg viewBox="0 10 120 130" xmlns="http://www.w3.org/2000/svg">
        <circle id="circle-1" cx="50" cy="50" r="50" fill="red"/>
        <circle id="circle-2" cx="50" cy="50" r="30" fill="orange"/>
        <circle id="circle-3" cx="50" cy="50" r="10" fill="yellow"/>
      </svg>
      """

      assert @xml_element_input
             |> Xml.update_attribute(name, value)
             |> Xml.export_string() ==
               expected
    end
  end

  describe "has_attribute?/2" do
    test "when it exists" do
      assert Xml.has_attribute?(@xml_element_input, :xmlns) == true
      assert Xml.has_attribute?(@xml_element_input, :viewBox) == true
    end

    test "when it does not exist" do
      assert Xml.has_attribute?(@xml_element_input, :foo) == false
      assert Xml.has_attribute?(@xml_element_input, :fill) == false
    end
  end

  describe "update_or_add_attribute/2" do
    test "adds attribute when does not exist" do
      name = :width
      value = ~c"120"

      expected = """
      <?xml version="1.0"?><svg width="120" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
        <circle id="circle-1" cx="50" cy="50" r="50" fill="red"/>
        <circle id="circle-2" cx="50" cy="50" r="30" fill="orange"/>
        <circle id="circle-3" cx="50" cy="50" r="10" fill="yellow"/>
      </svg>
      """

      assert @xml_element_input
             |> Xml.update_or_add_attribute(name, value)
             |> Xml.export_string() ==
               expected
    end

    test "updates attribute when already exists" do
      name = :viewBox
      value = ~c"0 10 120 130"

      expected = """
      <?xml version="1.0"?><svg viewBox="0 10 120 130" xmlns="http://www.w3.org/2000/svg">
        <circle id="circle-1" cx="50" cy="50" r="50" fill="red"/>
        <circle id="circle-2" cx="50" cy="50" r="30" fill="orange"/>
        <circle id="circle-3" cx="50" cy="50" r="10" fill="yellow"/>
      </svg>
      """

      assert @xml_element_input
             |> Xml.update_or_add_attribute(name, value)
             |> Xml.export_string() ==
               expected
    end
  end

  describe "charlist_to_number/1" do
    test "integers" do
      assert Xml.charlist_to_number(~c"1") == 1
      assert Xml.charlist_to_number(~c"32") == 32
    end

    test "floats" do
      assert Xml.charlist_to_number(~c"1.22") == 1.22
      assert Xml.charlist_to_number(~c"32.09989") == 32.09989
    end
  end

  describe "number_to_charlist/1" do
    test "integers" do
      assert Xml.number_to_charlist(1) == ~c"1"
      assert Xml.number_to_charlist(32) == ~c"32"
    end

    test "floats rounded to 2 decimal places" do
      assert Xml.number_to_charlist(1.22) == ~c"1.22"
      assert Xml.number_to_charlist(32.09989) == ~c"32.10"
    end
  end

  describe "combo" do
    test "shift colors to second part of the rainbow and make last circle smaller" do
      mapper = fn
        Xml.xmlElement() = element ->
          case Xml.find_attribute_value(element, :id) do
            nil ->
              element

            ~c"circle-1" ->
              Xml.update_or_add_attribute(element, :fill, "green")

            ~c"circle-2" ->
              Xml.update_or_add_attribute(element, :fill, "blue")

            ~c"circle-3" ->
              element = Xml.update_or_add_attribute(element, :fill, "purple")

              current_radius =
                element |> Xml.find_attribute_value(:r) |> Xml.charlist_to_number()

              new_radius = Xml.number_to_charlist(0.5 * current_radius)
              Xml.update_attribute(element, :r, new_radius)
          end

        other ->
          other
      end

      expected = """
      <?xml version="1.0"?><svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
        <circle id="circle-1" cx="50" cy="50" r="50" fill="green"/>
        <circle id="circle-2" cx="50" cy="50" r="30" fill="blue"/>
        <circle id="circle-3" cx="50" cy="50" r="5.00" fill="purple"/>
      </svg>
      """

      assert @xml_element_input
             |> Xml.traverse_and_update_elements(mapper)
             |> Xml.export_string() ==
               expected
    end
  end
end
