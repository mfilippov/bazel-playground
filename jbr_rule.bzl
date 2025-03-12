load("@rules_java//java:defs.bzl", "JavaInfo")

def _jbr_rule_impl(ctx):
    jbr_files = ctx.files.jbr_files

    java_info = ctx.attr.test_jar[JavaInfo]
    test_jar = java_info.outputs.jars[0].class_jar

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

    launch_info = ctx.actions.args().use_param_file("%s", use_always = True).set_param_file_format("multiline")
    launch_info.add("binary_type=Java")
    launch_info.add(ctx.workspace_name, format = "workspace_name=%s")
    launch_info.add("1", format = "symlink_runfiles_enabled=%s")
    launch_info.add(java_exe.short_path, format = "java_bin_path=%s")
    launch_info.add(ctx.attr.main_class, format = "java_start_class=%s")
    launch_info.add(ctx.file.test_jar.short_path, format = "classpath=%s")
    launch_info.add_joined(ctx.attr.jvm_flags, join_with = "\t", format_joined = "jvm_flags=%s", omit_if_empty = False)
    
    launcher_artifact = ctx.executable._launcher
    
    ctx.actions.run(
        executable = ctx.executable._launcher_maker,
        outputs = [executable],
        inputs = [launcher_artifact, test_jar],
        arguments = [launcher_artifact.path, launch_info, executable.path],
        use_default_shell_env = True
    )
    
    return [DefaultInfo(
        executable = executable,
        runfiles = ctx.runfiles(files = jbr_files + [test_jar]),
    )]


jbr_rule = rule(
    implementation = _jbr_rule_impl,
    executable = True,
    attrs = {
        "jbr_files": attr.label(allow_files = True, mandatory = True),
        "jvm_flags": attr.string_list(),
        "main_class": attr.string(mandatory = True),
        "test_jar": attr.label(allow_single_file = True, mandatory = True),
        "_launcher": attr.label(
            default = Label("@bazel_tools//tools/launcher:launcher"),
            executable = True,
            cfg = "exec",
        ),
        "_launcher_maker": attr.label(
            default = Label("@bazel_tools//tools/launcher:launcher_maker"),
            executable = True,
            cfg = "exec",
        ),
    },
)