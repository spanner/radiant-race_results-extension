var date_picker_options = {
  yearPicker: true,
  timePicker: true,
  dayShort: 3,
  format: 'D d M Y @ h:ia',
  inputOutputFormat: 'Y-m-d H:i:s',
  allowEmpty: true,
  positionOffset: { x: 20, y: -10 }
};

var AutoSlug = new Class({
  initialize: function (slugfield) {
    this.slug = slugfield;
    this.title = $(this.slug.id.replace('_slug', '_title'));
    this.old_title = this.title.value;
    this.title.addEvent('change', this.updateSlug.bind(this));
  },
  updateSlug: function () {
    if (this.old_title.toSlug() == this.slug.get('value')) {
      this.old_title = this.title.get('value');
      this.slug.set('value', this.old_title.toSlug());
    }
  }
});

activations.push(function (scope) {
  scope.getElements('input.date').each (function (input) { new DatePicker(input, date_picker_options); });
  scope.getElements('input.slug').each (function (input) { new AutoSlug(input); });
});
