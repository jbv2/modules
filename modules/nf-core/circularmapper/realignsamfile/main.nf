process CIRCULARMAPPER_REALIGNSAMFILE {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/circularmapper:1.93.5--h4a94de4_1':
        'biocontainers/circularmapper:1.93.5--h4a94de4_1' }"

    input:
    tuple val(meta), path(bam)
    tuple val(meta2), path(fasta)
    val(elong)

    output:
    tuple val(meta), path("*_realigned.bam")    , emit: bam
    path "versions.yml"                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}" // Module actually has a hard-coded output of {input}_realigned.bam
    def VERSION = '1.93.5' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.
    """
    realignsamfile \\
        -Xmx${task.memory.toGiga()}g \\
        ${args} \\
        -e $elong \\
        -i ${bam} \\
        -r ${fasta}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        CircularMapper: ${VERSION}
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def VERSION = '1.93.5' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.
    """
    touch ${prefix}_realigned.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        CircularMapper: ${VERSION}
    END_VERSIONS
    """
}
