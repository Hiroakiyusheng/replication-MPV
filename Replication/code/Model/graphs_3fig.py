# %%
import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib import font_manager as fm

# %%
# Configuration
fig_dimensions = (6, 2.1)  # in inches
font = "cmr10"  # Regular TeX font: Computer Modern Roman
font_size = 10
tick_length = 3  # in points
axis_linewidth = 1

# Styles
plt.rcParams.update(
    {
        # LaTeX font rendering
        # "text.usetex": True,
        # Fonts
        "font.size": font_size,
        # Layout
        "figure.constrained_layout.use": True,
    }
)
plt.style.use("seaborn-ticks")


def plot_data(ax, title, agg_data_rat, agg_data_beh, label_y=False):
    ax.plot(
        agg_data_rat["period"], agg_data_rat["consumption"], label="Rational Learners"
    )
    ax.plot(
        agg_data_beh["period"],
        agg_data_beh["consumption"],
        label="Experience-based Learners",
    )
    ax.set_title(title, fontname=font)
    ax.set_xlabel("Period", fontname=font)
    ax.tick_params(length=tick_length)
    for tick in ax.get_xticklabels():
        tick.set_fontname(font)
    for tick in ax.get_yticklabels():
        tick.set_fontname(font)
    if label_y:
        ax.set_ylabel("Consumption", fontname=font)
    # plt.legend()
    plt.xlim(0, 160)
    plt.ylim(2300, 6300)
    for axis in ["top", "bottom", "left", "right"]:
        ax.spines[axis].set_linewidth(axis_linewidth)


# %%
data_rat = pd.read_csv(
    "./../../data/simulations/straight_pistaferri/low_educ/reg_data_1.csv"
)
data_beh = pd.read_csv(
    "../../data/simulations/straight_pistaferri/low_educ/reg_data-beh_1.csv"
)

# %%

data_rat = data_rat.loc[data_rat["period"] <= 160, :]
data_beh = data_beh.loc[data_beh["period"] <= 160, :]

# %%
agg_data_rat_all = data_rat.groupby("period", as_index=False).agg("mean")
agg_data_beh_all = data_beh.groupby("period", as_index=False).agg("mean")

# %%
rat_bad = (data_rat["period"] == 30) & (data_rat["p_delta"] >= 0.1)
beh_bad = (data_beh["period"] == 30) & (data_beh["p_delta"] >= 0.1)
print(sum(rat_bad))
print(sum(beh_bad))
# %%
rat_bad_ids = data_rat["id"][rat_bad]
beh_bad_ids = data_beh["id"][beh_bad]
# %%
rat_bad_keeps = data_rat["id"].isin(rat_bad_ids)
beh_bad_keeps = data_beh["id"].isin(beh_bad_ids)

data_rat_bad = data_rat.loc[rat_bad_keeps, :]
data_beh_bad = data_beh.loc[beh_bad_keeps, :]

# %%
agg_data_rat_bad = data_rat_bad.groupby("period", as_index=False).agg("mean")
agg_data_beh_bad = data_beh_bad.groupby("period", as_index=False).agg("mean")


rat_good = (data_rat["period"] == 30) & (data_rat["p_delta"] <= 0.025)
beh_good = (data_beh["period"] == 30) & (data_beh["p_delta"] <= 0.025)
print(sum(rat_good))
print(sum(beh_good))
# %%
rat_good_ids = data_rat["id"][rat_good]
beh_good_ids = data_beh["id"][beh_good]
# %%
rat_good_keeps = data_rat["id"].isin(rat_good_ids)
beh_good_keeps = data_beh["id"].isin(beh_good_ids)

data_rat_good = data_rat.loc[rat_good_keeps, :]
data_beh_good = data_beh.loc[beh_good_keeps, :]

# %%
agg_data_rat_good = data_rat_good.groupby("period", as_index=False).agg("mean")
agg_data_beh_good = data_beh_good.groupby("period", as_index=False).agg("mean")

# %%
plt.close()
fig, (ax1, ax2, ax3) = plt.subplots(1, 3, figsize=fig_dimensions, sharey="row")

plot_data(ax1, "(a) Average", agg_data_rat_all, agg_data_beh_all, label_y=True)
plot_data(
    ax2, "(b) Bad Realizations \n Early in Life", agg_data_rat_bad, agg_data_beh_bad
)
plot_data(
    ax3, "(c) Good Realizations \n Early in Life", agg_data_rat_good, agg_data_beh_good
)

# Legend
handles, labels = ax1.get_legend_handles_labels()
legend = fig.legend(
    handles,
    labels,
    ncol=2,
    loc="lower center",
    bbox_to_anchor=(0.0, -0.15, 1.0, 1.0),
    prop=fm.FontProperties(family=font),
)

# plt.show()
plt.savefig("../../Figures/fig3.pdf", bbox_inches="tight", pad_inches=0.02)
# %%
