/**
 * Inspiration taken from the way Livebook deals with hook props:
 * https://github.com/livebook-dev/livebook/blob/main/assets/js/lib/attribute.js
 */
import normalize from "normalize-object";
const HOOK_PROPS_ATTR = "data-props";

export function parseHookProps(el, names = []) {
  const message = `Missing attribute "${HOOK_PROPS_ATTR}" on element ${el.tagName}#${el.id}`;
  if (!el.hasAttribute(HOOK_PROPS_ATTR)) throw new Error(message);

  const props = normalize(JSON.parse(el.getAttribute(HOOK_PROPS_ATTR)));

  for (const name of names) {
    const message = `Required prop ${name} not found on element ${el.tagName}#${el.id}`;
    if (!props.hasOwnProperty(name)) throw new Error(message);
  }

  return props;
}
