import click


# https://stackoverflow.com/questions/44247099/click-command-line-interfaces-make-options-required-if-other-optional-option-is
class RequiredIf(click.Option):
    def __init__(self, *args, **kwargs):
        self.required_if = kwargs.pop('required_if')
        assert self.required_if, "'required_if' parameter required"
        kwargs['help'] = (kwargs.get('help', '') +
                          ' NOTE: This argument must be provided if %s is specified' %
                          self.required_if).strip()
        super(RequiredIf, self).__init__(*args, **kwargs)

    def handle_parse_result(self, ctx, opts, args):
        we_are_not_present = self.name not in opts
        other_present = self.required_if in opts

        if other_present:
            if we_are_not_present:
                raise click.UsageError(
                    "Illegal usage: `%s` must be provided if `%s` is specified" % (
                        self.name, self.required_if))
            else:
                self.prompt = None

        return super(RequiredIf, self).handle_parse_result(
            ctx, opts, args)
