
# run the SQL Commands. This is a bit tricky, because SQL does not
# really play well on the cluster, so we don't parallelize this part


rule all_sql:
    input:
        sql = os.path.join(outdir, "SRAmetadb.sqlite")
    output:
        amp = os.path.join(outdir, "amplicons.ids"),
        som = os.path.join(outdir, "source_metagenomic.ids"),
        stm = os.path.join(outdir, "study_metagenomics.ids"),
        scm = os.path.join(outdir, "sci_name_metagenome.ids"),
    conda:
        "../envs/sqlite.yaml"
    shell:
        """
        sqlite3 {input.sql} 'select run_accession from run where experiment_accession in (select experiment_accession from experiment where (experiment.library_strategy = "AMPLICON" or experiment.library_selection = "PCR"))' > {output.amp}
        sqlite3 {input.sql} 'select run_accession from run where experiment_accession in (select experiment_accession from experiment where experiment.library_source = "METAGENOMIC")' > {output.som}
        sqlite3 {input.sql} 'select run_accession from run where experiment_accession in (select experiment_accession from experiment where experiment.study_accession in (select study_accession from study where study_type = "Metagenomics"));' > {output.stm}
        sqlite3 {input.sql} 'select run_accession from run where experiment_accession in (select experiment_accession from experiment where experiment.sample_accession in (select sample.sample_accession from sample where (sample.scientific_name like "%microbiom%" OR sample.scientific_name like "%metagenom%")))' > {output.scm}
        """

rule som_na:
    input:
        amp = os.path.join(outdir, "amplicons.ids"),
        som = os.path.join(outdir, "source_metagenomic.ids"),
    output:
        os.path.join(outdir, "source_metagenomic.notamplicons.ids")
    shell:
        "grep -F -x -v -f {input.amp} {input.som} > {output}"

rule stm_na:
    input:
        amp = os.path.join(outdir, "amplicons.ids"),
        stm = os.path.join(outdir, "study_metagenomics.ids"),
    output:
        os.path.join(outdir, "study_metagenomics.notamplicons.ids")
    shell:
        "grep -F -x -v -f {input.amp} {input.stm} > {output}"

rule scm_na:
    input:
        amp = os.path.join(outdir, "amplicons.ids"),
        scm = os.path.join(outdir, "sci_name_metagenome.ids"),
    output:
        os.path.join(outdir, "sci_name_metagenome.notamplicons.ids")
    shell:
        "grep -F -x -v -f {input.amp} {input.scm} > {output}"

rule combine_all:
    input:
        os.path.join(outdir, "source_metagenomic.notamplicons.ids"),
        os.path.join(outdir, "study_metagenomics.notamplicons.ids"),
        os.path.join(outdir, "sci_name_metagenome.notamplicons.ids")
    output:
        os.path.join(outdir, "SRA-metagenomes.txt")
    shell:
        "sort -u {input} >  {output}"

rule eliminate_already_done:
    input:
        old = "SRA_Metagenome_Types.tsv",
        new = os.path.join(outdir, "SRA-metagenomes.txt")
    output:
        os.path.join(outdir, "SRA-metagenomes-ToDownload.txt")
    shell:
        """
        cut -f 1 {input.old}  | grep -Fxvf - {input.new} > {output}
        """


