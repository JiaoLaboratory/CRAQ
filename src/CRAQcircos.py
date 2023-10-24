import argparse
import collections
import matplotlib.pyplot as plt
import pycircos

parser = argparse.ArgumentParser()
parser.add_argument('--genome_size', help='path to genome size file', type=str)
parser.add_argument("--genome_error_loc", help='path to genome error location file', type=str)
parser.add_argument("--genome_score", help='path to genome score file', type=str)
parser.add_argument('--scaffolds_ids', default=None, help='path to scaffolds ids file. Put the scaffolds ids you want to present into a file, one on each line', type=str)
parser.add_argument('--output', default='circos.pdf', help="output file", type=str)
args = parser.parse_args()



def draw_circos(genome_size,genome_error_loc,genome_score,scaffolds_ids,output):
    Garc = pycircos.Garc
    Gcircle = pycircos.Gcircle
    circle = Gcircle()

    # Get scaffolds ids that need to be presented
    scaffolds_ids_list = []
    f = genome_size if scaffolds_ids is None else scaffolds_ids
    with open(f) as fr:
        for line in fr:
             scaffolds_ids_list.append(line.strip().split()[0])


    # Set chromosomes
    length_list=[]
    with open(genome_size) as fr:
        for line in fr:
            line = line.strip().split()
            name = line[0]
            length = int(line[-1])
            length_list.append(length)
            if name in scaffolds_ids_list:
                arc = Garc(arc_id=name, size=length, interspace=3, raxis_range=(300, 400), labelposition=-100,
                           label_visible=True)
                circle.add_garc(arc)
    circle.set_garcs()


    # LER bar plot
    values_all = []
    arcdata_dict = collections.defaultdict(dict)
    with open(genome_error_loc) as fr:
        for line in fr:
            if 'LER' in line or 'CSE' in line:
                line = line.strip().split()
                name = line[0]
                start = int(line[1]) - max(length_list) / 1000
                end = int(line[1]) + max(length_list) / 1000
                width = end - start
                if name in scaffolds_ids_list:
                    if name not in arcdata_dict:
                        arcdata_dict[name]["positions"] = []
                        arcdata_dict[name]["widths"] = []
                        arcdata_dict[name]["values"] = []
                    arcdata_dict[name]["positions"].append(start)
                    arcdata_dict[name]["widths"].append(width)
                    arcdata_dict[name]["values"].append(1)
                    values_all.append(1)

    for key in arcdata_dict:
        circle.barplot(key, data=arcdata_dict[key]["values"], positions=arcdata_dict[key]["positions"],
                       width=arcdata_dict[key]["widths"], base_value=None,
                       rlim=[min(values_all), max(values_all)],
                       raxis_range=[450, 550], facecolor="r", spine=True)

    # SER bar plot
    values_all = []
    arcdata_dict = collections.defaultdict(dict)
    with open(genome_error_loc) as fr:
        for line in fr:
            if 'SER' in line or 'CRE' in line:
                line = line.strip().split()
                name = line[0]
                start = int(line[1]) - max(length_list)/2000
                end = int(line[1]) + max(length_list)/2000
                width = end - start
                if name in scaffolds_ids_list:
                    if name not in arcdata_dict:
                        arcdata_dict[name]["positions"] = []
                        arcdata_dict[name]["widths"] = []
                        arcdata_dict[name]["values"] = []
                    arcdata_dict[name]["positions"].append(start)
                    arcdata_dict[name]["widths"].append(width)
                    arcdata_dict[name]["values"].append(1)
                    values_all.append(1)

    for key in arcdata_dict:
        circle.barplot(key, data=arcdata_dict[key]["values"], positions=arcdata_dict[key]["positions"],
                       width=arcdata_dict[key]["widths"], base_value=None,
                       rlim=[min(values_all), max(values_all)],
                       raxis_range=[600, 700], facecolor="g", spine=True)


    # AQI line
    values_all = []
    arcdata_dict = collections.defaultdict(dict)
    with open(genome_score) as fr:
        for line in fr.readlines()[1:]:
            line = line.strip().split()
            name = line[0]
            start = int(line[1])
            end = int(line[2])
            mid = start+(end - start)/2
            value = float(line[-1])
            values_all.append(value)
            if name in scaffolds_ids_list:
                if name not in arcdata_dict:
                    arcdata_dict[name]["positions"] = []
                    arcdata_dict[name]["values"] = []
                arcdata_dict[name]["positions"].append(mid)
                arcdata_dict[name]["values"].append(value)

    vmin, vmax = min(values_all), max(values_all)
    for key in arcdata_dict:
        positions2values = dict(zip(arcdata_dict[key]["positions"],arcdata_dict[key]["values"]))
        positions2values = dict(sorted(positions2values.items(),key=lambda x:x[0]))
        circle.lineplot(key, data=list(positions2values.values()),
                        positions=list(positions2values.keys()),
                        rlim=[vmin-0.05*abs(vmin), vmax+0.05*abs(vmax)],
                        raxis_range=[750, 1000],linecolor="royalblue", spine=True)


    # savefig
    circle.figure.savefig(output)



if __name__ == '__main__':
    draw_circos(genome_size=args.genome_size,
                genome_error_loc=args.genome_error_loc,
                genome_score=args.genome_score,
                scaffolds_ids=args.scaffolds_ids,
                output=args.output)
