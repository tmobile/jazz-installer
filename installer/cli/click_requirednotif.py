import click


# https://stackoverflow.com/questions/44247099/click-command-line-interfaces-make-options-required-if-other-optional-option-is
class RequiredNotIf(click.Option):
    def __init__(self, *args, **kwargs):
        self.required_not_if = kwargs.pop('required_not_if')
        assert self.required_not_if, "'required_not_if' parameter required"
        kwargs['help'] = (kwargs.get('help', '') +
                          ' NOTE: This argument is only required if %s is not specified' %
                          self.required_not_if).strip()
        super(RequiredNotIf, self).__init__(*args, **kwargs)

    def handle_parse_result(self, ctx, opts, args):
        we_are_present = self.name in opts
        other_present = self.required_not_if in opts

        if other_present:
            if we_are_present:
                raise click.UsageError(
                    "Illegal usage: `%s` is only required if `%s` is not specified" % (
                        self.name, self.required_not_if))
            else:
                self.prompt = None

        return super(RequiredNotIf, self).handle_parse_result(
            ctx, opts, args)
