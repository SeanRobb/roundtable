import React from 'react';
import { cleanup, render } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import Board from './board';

describe('<Board />', () => {
  afterEach(cleanup);

  test('it should mount', () => {
    const { getByTestId } = render(<Board />);
    const board = getByTestId('board');

    expect(board).toBeInTheDocument();
  });
});