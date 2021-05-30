# -*- coding: utf-8 -*-

import os
import pandas as pd


def getTax():

    import tarfile

    os.system('wget https://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz')

    tar = tarfile.open('taxdump.tar.gz', "r:gz")
    tar.extractall()
    tar.close()


def getChildren(taxids, base_path=None):

    if base_path is None:
        f = 'nodes.dmp'
    else:
        f = base_path.rstrip('/')+'/nodes.dmp'

    df = pd.read_csv(f,
                     sep='\t|\t',
                     header=None,
                     engine='python')

    children = pd.Series(taxids)
    j = children.index.size
    for i in df.index:
        if df[2][i] in taxids:
            children[j] = df[0][i].item()
            j = j+1

    a = [1, j]
    if a[0]-a[1] == 0:
        print('The input node has no child nodes.')

    while a[0]-a[1] != 0:
        for i in range(a[0], a[1]):
            for k in df.index[df[2] == children[i]]:
                if df[2][k] == children[i]:
                    children[j] = df[0][k].item()
                    j = j+1
        a = [a[1], j]

    return children.tolist()


def load_fin(fin):

    return pd.read_csv(fin)


def TaxSlice(fin, fo, taxids, exclude=False, base_path=None):

    df = load_fin(fin)
    taxid_col = df.columns[0]

    if base_path is None:
        getTax()

    children = getChildren(taxids, base_path)

    if exclude:
        df = df[~df[taxid_col].isin(children)]
        df.to_csv(fo, index=False)
        return df
    else:
        df = df[df[taxid_col].isin(children)]
        df.to_csv(fo, index=False)
        return df


if __name__ == "__main__":

    import argparse

    parser = argparse.ArgumentParser()

    parser.add_argument('-fin',
                        help='input taxid file, should include a header row, \
                        and if more than one column, shoudl be comma delimted \
                        with taxids in the first column',
                        type=str)

    parser.add_argument('-fo',
                        help='the name of the output file',
                        type=str)

    parser.add_argument('-taxids',
                        help='a single taxid or \
                        a comma separated list of taxids',
                        type=str)

    parser.add_argument('-exclude',
                        help='either "True" or "False" \
                        if True, child taxids will be excluded \
                        from the input files taxids',
                        default=False)

    parser.add_argument('-base_path',
                        help='the directory in which "nodes.dmp" is located. \
                        By default the file will be downloaded from \
                        the NCBI Taxonomy FTP',
                        default=None)

    args = parser.parse_args()
    fin = args.fin
    fo = args.fo
    taxids = [int(x) for x in args.taxids.split(',')]
    exclude = args.exclude
    base_path = args.base_path

    TaxSlice(fin, fo, taxids, exclude, base_path)
