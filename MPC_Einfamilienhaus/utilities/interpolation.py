import numpy as np
import math
from typing import Union, List
import pandas as pd
from scipy.interpolate import interpolate

def sample(
        trajectory: Union[float, int, pd.Series, List[Union[float, int]]],
        grid: Union[list, np.ndarray],
        current: float = 0,
        method: str = 'linear') -> list:
    """
    Obtain the specified portion of the trajectory.

    Args:
        trajectory:  The trajectory to be sampled. Scalars will be
            expanded onto the grid. Lists need to exactly match the provided
            grid. Otherwise, a list of tuples is accepted with the form (
            timestamp, value). A dict with the keys 'grid' and 'value' is also
            accepted.
        current: start time of requested trajectory
        grid: target interpolation grid in seconds in relative terms (i.e.
            starting from 0 usually)
        method: interpolation method, currently accepted: 'linear',
            'spline', 'previous'

    Returns:
        Sampled list of values.

    Takes a slice of the trajectory from the current time step with the
    specified length and interpolates it to match the requested sampling.
    If the requested horizon is longer than the available data, the last
    available value will be used for the remainder.

    Raises:
        ValueError
        TypeError
    """
    n = len(grid)
    if isinstance(trajectory, (float, int)):
        # return constant trajectory for scalars
        return [trajectory] * n
    if isinstance(trajectory, list):
        # return lists of matching length without timestamps
        if len(trajectory) == len(grid):
            return trajectory
        raise ValueError(f"Passed list with length {len(trajectory)} "
                         f"does not match target ({len(grid)}).")
    if isinstance(trajectory, pd.Series):
        source_grid = np.array(trajectory.index)
        values = trajectory.values
    else:
        raise TypeError(f"Passed trajectory of type '{type(trajectory)}' "
                        f"cannot be sampled.")
    target_grid = np.array(grid) + current

    # expand scalar values
    if len(source_grid) == 1:
        return [trajectory[0]] * len(target_grid)

    # skip resampling if grids are (almost) the same
    if (target_grid.shape == source_grid.shape) \
            and all(target_grid == source_grid):
        return list(values)
    values = np.array(values)

    # check requested portion of trajectory
    if current > source_grid[-1]:
        # return the last value of the trajectory if requested sample
        # starts out of range
        logger.warning(
            f"Latest value of source grid %s is older than "
            f"current time (%s. Returning latest value anyway.",
            source_grid[-1], current)
        return [values[-1]] * n

    def get_end(inner):
        """
        Gets the last value on the new grid which is within
        interpolation range. Returns a tuple of this value as
        unixtime and the number of necessary extrapolation intervals.
        """
        # TODO: this failed with 1 entry pd.Series
        end_request = target_grid[inner - 1]
        if end_request < source_grid[-1]:
            return n - inner
        return get_end(inner - 1)

    extra = get_end(n)

    # shorten target interpolation grid by extra points that go above
    # available data range
    target_grid = target_grid[:n - extra]

    # interpolate data to match new grid
    if method == 'linear':
        tck = interpolate.interp1d(x=source_grid, y=values,
                                   kind='linear')
        sequence_new = list(tck(target_grid))
    elif method == 'spline':
        tck = interpolate.make_interp_spline(source_grid, values)
        sequence_new = list(tck(target_grid))
    elif method == 'previous':
        tck = interpolate.interp1d(source_grid, values, kind='previous')
        sequence_new = list(tck(target_grid))
    else:
        raise ValueError(
            f"Chosen 'method' {method} is not a valid method. "
            f"Currently supported: linear, spline, previous")

    # extrapolate sequence with last available value if necessary
    sequence_new.extend([values[-1]] * extra)

    return sequence_new