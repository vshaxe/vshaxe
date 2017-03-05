package builders;

/** sounds like an RTS... **/
class BaseBuilder implements IBuilder {
    var cli:CliTools;
    var project:Project;

    public function new(cli:CliTools, project:Project) {
        this.cli = cli;
        this.project = project;
    }

    public function build(config:Config) {}
}