import argparse
import collections
import matplotlib.pyplot as plt
import pycircos

parser = argparse.ArgumentParser()
parser.add_argument('--genome_size', help='path to genome size file', type=str)
parser.add_argument("--genome_error_loc", help='path to genome error location file', type=str)
parser.add_argument("--genome_score", help='path to genome score file', type=str)
parser.add_argument('--output', default='circos.pdf', help="output file", type=str)
args = parser.parse_args()

def draw_circos(genome_size,genome_error_loc,genome_score,output):
    Garc = pycircos.Garc
    Gcircle = pycircos.Gcircle

    # Set chromosomes
    length_list=[]
    circle = Gcircle()
    with open(genome_size) as fr:
        for line in fr:
            line = line.strip().split()
            name = line[0]
            length = int(line[-1])
            length_list.append(length)
            arc = Garc(arc_id=name, size=length, interspace=3, raxis_range=(950, 1000), labelposition=60,
                       label_visible=True)
            circle.add_garc(arc)
    circle.set_garcs()

    # bar plot
    values_all = []
    arcdata_dict = collections.defaultdict(dict)
    with open(genome_error_loc) as fr:
        for line in fr:
            if 'SER' in line:
                line = line.strip().split()
                name = line[0]
                start = int(line[1]) - max(length_list)/1000
                end = int(line[1]) + max(length_list)/1000
                width = end - start
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
                       raxis_range=[800, 850], facecolor="g", spine=True)

    # bar plot
    values_all = []
    arcdata_dict = collections.defaultdict(dict)
    with open(genome_error_loc) as fr:
        for line in fr:
            if 'LER' in line:
                line = line.strip().split()
                name = line[0]
                start = int(line[1]) - max(length_list) / 1000
                end = int(line[1]) + max(length_list) / 1000
                width = end - start
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
                       raxis_range=[700, 750], facecolor="r", spine=True)

    # heatmap
    values_all = []
    arcdata_dict = collections.defaultdict(dict)
    with open(genome_score) as fr:
        for line in fr.readlines()[1:]:
            line = line.strip().split()
            name = line[0]
            start = int(line[1]) - 1
            end = int(line[2])
            width = end - start
            if name not in arcdata_dict:
                arcdata_dict[name]["positions"] = []
                arcdata_dict[name]["widths"] = []
                arcdata_dict[name]["values"] = []
            arcdata_dict[name]["positions"].append(start)
            arcdata_dict[name]["widths"].append(width)
            arcdata_dict[name]["values"].append(float(line[-1]))
            values_all.append(float(line[-1]))

    for key in arcdata_dict:
        circle.heatmap(key, data=arcdata_dict[key]["values"], positions=arcdata_dict[key]["positions"],
                       width=arcdata_dict[key]["widths"], raxis_range=[600, 650], vmin=0, vmax=100,
                       cmap=plt.cm.YlOrRd)

    # savefig
    circle.figure.savefig(output)



if __name__ == '__main__':
    draw_circos(genome_size=args.genome_size,
                                  genome_error_loc=args.genome_error_loc,
                                  genome_score=args.genome_score,
                                  output=args.output)

