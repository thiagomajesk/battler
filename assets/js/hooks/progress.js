import { parseHookProps } from "../utils/attribute";

const REQUIRED_PROPS = ["mainId", "trailId", "value", "delay"];

const PROGRESS_DIRECTION = Object.freeze({
  INCREASING: Symbol("INCREASING"),
  DECREASING: Symbol("DECREASING"),
});

export default {
  initialize() {
    this.props = parseHookProps(this.el, REQUIRED_PROPS);

    this.mainProgress = document.getElementById(this.props.mainId);
    this.trailProgress = document.getElementById(this.props.trailId);

    this.direction =
      this.props.value > this.lastValue
        ? PROGRESS_DIRECTION.INCREASING
        : PROGRESS_DIRECTION.DECREASING;

    this.lastValue = this.props.value;
  },

  mounted() {
    this.initialize();
    updateProgressWidth(this.mainProgress, this.props.value);
    updateProgressWidth(this.trailProgress, this.props.value);
    this.updateDOM();
  },

  updated() {
    this.initialize();
    this.updateDOM();
  },

  destroyed() {
    clearTimeout(this.timeout);
  },

  updateDOM() {
    clearTimeout(this.timeout);

    switch (this.direction) {
      case PROGRESS_DIRECTION.INCREASING:
        updateProgressWidth(this.trailProgress, this.props.value);
        this.timeout = setTimeout(() => {
          updateProgressWidth(this.mainProgress, this.props.value);
        }, this.props.delay);
        break;
      case PROGRESS_DIRECTION.DECREASING:
        updateProgressWidth(this.mainProgress, this.props.value);
        this.timeout = setTimeout(() => {
          updateProgressWidth(this.trailProgress, this.props.value);
        }, this.props.delay);
        break;
    }
  },
};

function updateProgressWidth(progress, value) {
  progress.style.width = `${value}%`;
}
