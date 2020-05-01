$(function () {
  // On load, order the selections by the order they were originally selected
  // in rather than how the drop down selection is ordered.

  function findObjectByKey(array, key, value) {
    for (var i = 0; i < array.length; i++) {
      if (array[i][key] === value) {
        return array[i]
      }
    }
    return null
  }
})
