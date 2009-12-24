document.observe('dom:loaded', function() {

  when('race_name', function(title) {
    var slug = $('race_slug'),
        oldTitle = title.value;
    if (!slug) return;
    new Form.Element.Observer(title, 0.15, function() {
      if (oldTitle.toSlug() == slug.value) slug.value = title.value.toSlug();
      oldTitle = title.value;
    });
  });
  when('race_instance_name', function(title) {
    var slug = $('race_instance_slug'),
        oldTitle = title.value;
    if (!slug) return;
    new Form.Element.Observer(title, 0.15, function() {
      if (oldTitle.toSlug() == slug.value) slug.value = title.value.toSlug();
      oldTitle = title.value;
    });
  });
});