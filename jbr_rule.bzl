def _jbr_rule_impl(ctx):
    jbr_files = ctx.files.jbr_files
    java_exe = None
    for file in jbr_files:
        if file.basename == "java.exe":
            java_exe = file
            break
    if java_exe == None:
        fail("java.exe not found in 'jbr_files'")


    # Create a more robust launcher using Bazel's native capabilities
    executable = ctx.actions.declare_file(ctx.label.name + ".exe")
    
    # Format the arguments
    args = ctx.attr.params if hasattr(ctx.attr, "params") else []
    
    # Use Bazel's launcher_maker
    ctx.actions.run(
        executable = ctx.executable._launcher_maker,
        outputs = [executable],
        inputs = [],
        arguments = [
            "--output", executable.path,
            "--launcher_type", "WINDOWS",
            "--workspace_name", ctx.workspace_name,
            "--exec_path", java_exe.short_path,
            "--args", " ".join(args),
        ],
    )
    
    return [DefaultInfo(
        executable = executable,
        runfiles = ctx.runfiles(files = jbr_files),
    )]

jbr_rule = rule(
    implementation = _jbr_rule_impl,
    executable = True,
    attrs = {
        "jbr_files": attr.label(allow_files = True, mandatory = True),
        "params": attr.string_list(),
        "_launcher_maker": attr.label(
            default = Label("@bazel_tools//tools/launcher:launcher_maker"),
            executable = True,
            cfg = "exec",
        ),
    },
)