# This is an alternate way to get the information. This file has the SRA Accessions and
# the title of the project. We could search this for metagenomes, etc

rule download_SRA_Accessions:
    output:
        os.path.join(outdir, "SRA_Accessions.tab")
    shell:
        """
        curl -Lo {output} ftp://ftp.ncbi.nlm.nih.gov/sra/reports/Metadata/SRA_Accessions.tab
        """
