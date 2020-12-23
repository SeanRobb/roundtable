import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import BetList from './betList';

describe('<BetList />', () => {
  test('it should mount', () => {
    render(<BetList />);
    
    const betList = screen.getByTestId('BetList');

    expect(betList).toBeInTheDocument();
  });
});