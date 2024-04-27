import "./phx";
import "./events";
import "iconify-icon";
import autoAnimate from "@formkit/auto-animate";

const autoAnimateList = document.querySelectorAll("[data-auto-animate]");
Array.from(autoAnimateList).forEach((element) => autoAnimate(element));