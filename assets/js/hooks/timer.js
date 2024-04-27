import { parseHookProps } from "../utils/attribute";

const UPDATE_INTERVAL = 100;

/**
 * A hook that is used to display a counting timer.
 *
 * ## Props
 *
 *  * `start` - the value in milliseconds to count from
 */
export default {
  initialize() {
    this.props = parseHookProps(this.el);
    this.target = this.el.querySelector(`:scope${this.props.target}`);
  },

  mounted() {
    this.initialize();
    this.interval = setInterval(() => this.updateDOM(), UPDATE_INTERVAL);
  },

  updated() {
    this.initialize();
    this.updateDOM();
  },

  destroyed() {
    clearInterval(this.interval);
  },

  updateDOM() {
    // NOTE: The start prop could actually be a data, but then we would have
    // to take the user's browser timezone which can get tricky. Currently,
    // the easiest and safest wayof doing this is to just compute the relative utc 
    // on the server and then get the remaining time in milliseconds to countdown from.
    // const elapsedMs = new Date(this.props.start) - Date.now();
    // const elapsedSeconds = elapsedMs / 1_000;

    this.props.start -= UPDATE_INTERVAL;
    const elapsedSeconds = this.props.start / 1_000;

    if (elapsedSeconds <= 0) {
      clearInterval(this.interval);
    }

    if (elapsedSeconds <= 10) {
      this.el.setAttribute("data-warning", elapsedSeconds);
    }

    this.target.innerHTML = `${elapsedSeconds.toFixed(1)}s`;
  },
};
