import * as u from 'JS/utils'

u.domReady(() => {
  document.addEventListener('DOMContentLoaded', (event) => {
    document.getElementsByClassName('test')[0].addEventListener('click', () => {
      console.log('Whoooop!')
    })
  })
})
