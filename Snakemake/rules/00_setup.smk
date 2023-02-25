########################################################################
##                                                                    ##
## Snakemake                                                          ##
##                                                                    ##
## Step 1: set up the files                                           ##
##                                                                    ##
########################################################################


rule get_mod_time:
    output:
        os.path.join(outdir, "timestamp.txt")
    shell:
        """
        curl --head https://s3.amazonaws.com/starbuck1/sradb/SRAmetadb.sqlite.gz > {output}
        """





