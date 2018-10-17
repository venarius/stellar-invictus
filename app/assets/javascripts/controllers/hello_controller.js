(() => {
  stimulus.register("hello", class extends Stimulus.Controller {
    static get targets() {
      return [ "output" ]
    }
    connect() {
      this.outputTarget.textContent = 'Hello, Stimulus!'
    }
  })
})()