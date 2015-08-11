$ ->
      flashCallback = ->
        $(".alert").fadeOut(1000)
      $(".alert").bind 'click', (ev) =>
        $(".alert").fadeOut()
      setTimeout flashCallback, 2000
