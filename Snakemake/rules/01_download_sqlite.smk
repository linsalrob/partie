
# Download one of the SRA SQLite databases:
#

rule download_sqlite:
    output:
        os.path.join(outdir, "SRAmetadb.sqlite.gz")
    conda:
        "../envs/downloads.yaml"
    shell:
        """
        curl -Lo {output} 'https://s3.amazonaws.com/starbuck1/sradb/SRAmetadb.sqlite.gz'
        """

rule extract_sqlite:
    input:
        os.path.join(outdir, "SRAmetadb.sqlite.gz")
    output:
        os.path.join(outdir, "SRAmetadb.sqlite")
    resources:
        mem_mb=20000,
        cpus=16
    conda:
        "../envs/downloads.yaml"
    shell:
        """
        unpigz {input}
        """



