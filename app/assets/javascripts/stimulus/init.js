//= require stimulus.umd
(() => {
  if (!("stimulus" in window)) {
    window.stimulus = Stimulus.Application.start()
  }
})()