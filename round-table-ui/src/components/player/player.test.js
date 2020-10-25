import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import Player from './player';

describe('<Player />', () => {
  test('it should mount', () => {
    render(<Player />);
    
    const Player = screen.getByTestId('Player');

    expect(Player).toBeInTheDocument();
  });
});