defmodule BattlerWeb.Components do
  use Phoenix.Component

  @doc """
  Takes the given assigns and converts them into a props attribute.
  """
  def assign_props(assigns, fun) do
    case fun.(assigns) do
      props when is_map(props) ->
        assign(assigns, :props, Jason.encode!(props))

      result ->
        raise "Expected a map, got #{inspect(result)}"
    end
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(BattlerWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(BattlerWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end
