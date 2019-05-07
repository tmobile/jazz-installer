import click


# https://stackoverflow.com/questions/44247099/click-command-line-interfaces-make-options-required-if-other-optional-option-is
class Required(click.Option):
    def __init__(self, *args, **kwargs):
        required_if = kwargs.pop('required_if', None)
        required_if_not = kwargs.pop('required_if_not', None)
        assert (required_if or required_if_not), "'required_if/if_not' parameter required"
        if required_if:
            self.required_if = required_if
            kwargs['help'] = (kwargs.get('help', '') +
                              ' NOTE: This argument must be provided if %s is specified' %
                              self.required_if).strip()
        elif required_if_not:
            self.required_if_not = required_if_not
            kwargs['help'] = (kwargs.get('help', '') +
                              ' NOTE: This argument is only required if %s is not specified' %
                              self.required_if_not).strip()
        super(Required, self).__init__(*args, **kwargs)

    def handle_parse_result(self, ctx, opts, args):
        if hasattr(self, 'required_if'):
            we_are_not_present = self.name not in opts
            other_present = self.required_if in opts

            if other_present:
                if we_are_not_present:
                    raise click.UsageError(
                        "Illegal usage: `%s` must be provided if `%s` is specified" % (
                            self.name, self.required_if))
            else:
                self.prompt = None
        elif hasattr(self, 'required_if_not'):
            we_are_present = self.name in opts
            other_present = self.required_if_not in opts

            if other_present:
                if we_are_present:
                    raise click.UsageError(
                        "Illegal usage: `%s` is only required if `%s` is not specified" % (
                            self.name, self.required_if_not))
                else:
                    self.prompt = None

        return super(Required, self).handle_parse_result(
            ctx, opts, args)
