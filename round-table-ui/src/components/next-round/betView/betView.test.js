import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import BetView from './betView';

describe('<BetView />', () => {
  test('it should mount', () => {
    render(<BetView />);
    
    const betView = screen.getByTestId('BetView');

    expect(betView).toBeInTheDocument();
  });
});